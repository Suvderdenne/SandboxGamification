import jwt
from datetime import datetime, timedelta, timezone
from uuid import uuid4
from django.conf import settings
from .models import BlacklistedToken

def create_token(user_id):
    jti = str(uuid4())
    exp = datetime.now(timezone.utc) + timedelta(hours=getattr(settings, "JWT_EXP_HOURS", 24))
    payload = {
        "user_id": user_id,
        "exp": exp,
        "iat": datetime.now(timezone.utc),
        "jti": jti,
    }
    token = jwt.encode(payload, settings.JWT_SECRET, algorithm=settings.JWT_ALGORITHM)
    return token

def decode_token(token):
    """
    Токеныг decode хийж payload буцаана.
    Хэрвээ хүчин төгөлдөр биш бол (expiration, invalid) -> Exception болон None буцааж болно.
    Манай хэрэглээнд None буцааж хүчингүй болгосон.
    """
    try:
        payload = jwt.decode(token, settings.JWT_SECRET, algorithms=[settings.JWT_ALGORITHM])
        # blacklist шалгах
        jti = payload.get("jti")
        if not jti:
            return None
        # хэрвээ blacklisted бол None буцаах
        if BlacklistedToken.objects.filter(jti=jti).exists():
            return None
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None

def blacklist_token_by_jti(jti, expires_at):
    """
    Logout үед blacklisting хийхэд ашиглана.
    """
    BlacklistedToken.objects.create(jti=jti, expires_at=expires_at)
