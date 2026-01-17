# D:/01. Projects/Sandbox_Club/SandboxGamification/backend/firstApp/views.py
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt, ensure_csrf_cookie
from django.middleware.csrf import get_token
from datetime import datetime, timezone
import json

from .models import User
from .utils import create_token, decode_token, blacklist_token_by_jti
from .decorators import jwt_required


@ensure_csrf_cookie
def get_csrf(request):
    """CSRF токен авах"""
    token = get_token(request)
    print(token)
    return JsonResponse({
        "csrfToken": token,
        "message": "CSRF токен амжилттай илгээгдлээ"
    }, status=200)



@csrf_exempt
def register(request):
    """Шинэ хэрэглэгч бүртгэх"""
    if request.method != "POST":
        return JsonResponse(
            {"error": "Зөвхөн POST хүсэлт илгээх боломжтой"},
            status=405
        )

    try:
        data = json.loads(request.body)
    except Exception:
        return JsonResponse({"error": "JSON формат буруу байна"}, status=400)

    username = data.get("username")
    email = data.get("email")
    password = data.get("password")

    if not username or not password or not email:
        return JsonResponse(
            {"error": "Хэрэглэгчийн нэр, и-мэйл, нууц үг шаардлагатай"},
            status=400
        )

    if User.objects.filter(username=username).exists():
        return JsonResponse(
            {"error": "Ийм хэрэглэгч аль хэдийн бүртгэлтэй байна"},
            status=400
        )

    user = User(username=username, email=email, verified='N')  # ✅ gmail → email
    user.set_password(password)
    user.save()

    return JsonResponse(
        {"message": "Бүртгэл амжилттай хийгдлээ"},
        status=201
    )



@csrf_exempt
def login(request):
    """Хэрэглэгч нэвтрэх"""
    if request.method != "POST":
        return JsonResponse(
            {"error": "Зөвхөн POST хүсэлт илгээх боломжтой"},
            status=405
        )

    try:
        data = json.loads(request.body)
    except Exception:
        return JsonResponse({"error": "JSON формат буруу байна"}, status=400)

    username = data.get("username")
    password = data.get("password")
    verified = data.get("verified")

    if not username or not password:
        return JsonResponse(
            {"error": "Хэрэглэгчийн нэр болон нууц үг шаардлагатай"},
            status=400
        )

    try:
        user = User.objects.get(username=username)

    except User.DoesNotExist:
        return JsonResponse({"error": "Нэвтрэх мэдээлэл буруу байна"}, status=400)

    if not user.check_password(password):
        return JsonResponse({"error": "Нууц үг таарахгүй байна"}, status=400)
    
    if user.check_verified(verified):
        return JsonResponse({"error": "Баталгаажуулаагүй байна"}, status=400)

    token = create_token(user.id)
    return JsonResponse({
        "message": "Амжилттай нэвтэрлээ",
        "token": token,
        "user_id": user.id  # ✅ user_id буцаах
    }, status=200)



@jwt_required
def profile(request):
    """Хэрэглэгчийн профайл мэдээлэл"""
    user = request.user
    return JsonResponse({
        "id": user.id,  # ✅ id нэмэх
        "username": user.username,
        "email": user.email,  # ✅ gmail → email
        "message": "Хэрэглэгчийн мэдээлэл амжилттай уншигдлаа"
    }, status=200)



@csrf_exempt
@jwt_required
def logout(request):
    """JWT токеноор гаргах"""
    payload = getattr(request, "jwt_payload", None)
    if not payload:
        return JsonResponse({"error": "Токен олдсонгүй"}, status=400)

    jti = payload.get("jti")
    exp_timestamp = payload.get("exp")

    if isinstance(exp_timestamp, (int, float)):
        expires_at = datetime.fromtimestamp(exp_timestamp, tz=timezone.utc)
    else:
        expires_at = exp_timestamp

    blacklist_token_by_jti(jti, expires_at)
    return JsonResponse({"message": "Амжилттай гарлаа"}, status=200)
