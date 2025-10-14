from django.http import JsonResponse
from functools import wraps
from .utils import decode_token
from .models import User

def jwt_required(view_func):
    @wraps(view_func)
    def _wrapped(request, *args, **kwargs):
        auth = request.headers.get("Authorization") or request.META.get("HTTP_AUTHORIZATION")
        if not auth:
            return JsonResponse({"error": "Authorization header required"}, status=401)
        parts = auth.split()
        if len(parts) != 2 or parts[0].lower() != "bearer":
            return JsonResponse({"error": "Authorization header must be Bearer token"}, status=401)
        token = parts[1]
        payload = decode_token(token)
        if not payload:
            return JsonResponse({"error": "Invalid or expired token"}, status=401)
        try:
            user = User.objects.get(id=payload["user_id"])
        except User.DoesNotExist:
            return JsonResponse({"error": "User not found"}, status=401)
        # request-д user болон token payload нэмэх
        request.user = user
        request.jwt_payload = payload
        return view_func(request, *args, **kwargs)
    return _wrapped
