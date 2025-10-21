from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json
from firstApp.decorators import jwt_required
from .models import QuizProgress, QuizDetail, UserScore
from quizApp.models import Quiz, Option
from firstApp.models import User

# ==========================
# QuizProgress Views
# ==========================
@csrf_exempt
@jwt_required
def quiz_progress_list(request):
    if request.method == "GET":
        progress = list(QuizProgress.objects.all().values())
        return JsonResponse({"status": 200, "data": progress})
    elif request.method == "POST":
        try:
            data = json.loads(request.body)
            if isinstance(data, list):
                objs = []
                for item in data:
                    quiz = Quiz.objects.get(id=item['test_id'])
                    user = User.objects.get(id=item['user_id'])
                    objs.append(QuizProgress(
                        test_id=quiz,
                        user_id=user,
                        required_score=item['required_score'],
                        achieved_score=item['achieved_score']
                    ))
                QuizProgress.objects.bulk_create(objs)
                return JsonResponse({"message": f"{len(objs)} прогрессийн бичлэг амжилттай үүсгэгдлээ"}, status=201)
            elif isinstance(data, dict):
                quiz = Quiz.objects.get(id=data['test_id'])
                user = User.objects.get(id=data['user_id'])
                progress = QuizProgress.objects.create(
                    test_id=quiz,
                    user_id=user,
                    required_score=data['required_score'],
                    achieved_score=data['achieved_score']
                )
                return JsonResponse({
                    "id": progress.id,
                    "test_id": progress.test_id.id,
                    "user_id": progress.user_id.id,
                    "required_score": str(progress.required_score),
                    "achieved_score": str(progress.achieved_score),
                    "message": "Прогрессийн бичлэг амжилттай үүсгэгдлээ"
                }, status=201)
            else:
                return JsonResponse({"error": "Алдаатай JSON формат"}, status=400)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

@csrf_exempt
@jwt_required
def quiz_progress_detail(request, progress_id):
    try:
        progress = QuizProgress.objects.get(id=progress_id)
    except QuizProgress.DoesNotExist:
        return JsonResponse({"error": "Прогрессийн бичлэг олдсонгүй"}, status=404)
    
    if request.method == "GET":
        return JsonResponse({
            "status": 200,
            "id": progress.id,
            "test_id": progress.test_id.id,
            "user_id": progress.user_id.id,
            "required_score": str(progress.required_score),
            "achieved_score": str(progress.achieved_score)
        })
    elif request.method == "PUT":
        try:
            data = json.loads(request.body)
            if 'test_id' in data:
                progress.test_id = Quiz.objects.get(id=data['test_id'])
            if 'user_id' in data:
                progress.user_id = User.objects.get(id=data['user_id'])
            if 'required_score' in data:
                progress.required_score = data['required_score']
            if 'achieved_score' in data:
                progress.achieved_score = data['achieved_score']
            progress.save()
            return JsonResponse({"message": "Прогрессийн бичлэг амжилттай шинэчлэгдлээ", "status": 200})
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)
    elif request.method == "DELETE":
        progress.delete()
        return JsonResponse({"message": "Прогрессийн бичлэг амжилттай устгагдлаа", "status": 200})

# ==========================
# QuizDetail Views
# ==========================
@csrf_exempt
@jwt_required
def quiz_detail_list(request):
    if request.method == "GET":
        details = list(QuizDetail.objects.all().values())
        return JsonResponse({"status": 200, "data": details})
    elif request.method == "POST":
        try:
            data = json.loads(request.body)
            if isinstance(data, list):
                objs = []
                for item in data:
                    quiz = Quiz.objects.get(id=item['test_id'])
                    user = User.objects.get(id=item['user_id'])
                    option = Option.objects.get(id=item['option_id'])
                    objs.append(QuizDetail(
                        test_id=quiz,
                        user_id=user,
                        option_id=option
                    ))
                QuizDetail.objects.bulk_create(objs)
                return JsonResponse({"message": f"{len(objs)} дэлгэрэнгүй бичлэг амжилттай үүсгэгдлээ"}, status=201)
            elif isinstance(data, dict):
                quiz = Quiz.objects.get(id=data['test_id'])
                user = User.objects.get(id=data['user_id'])
                option = Option.objects.get(id=data['option_id'])
                detail = QuizDetail.objects.create(
                    test_id=quiz,
                    user_id=user,
                    option_id=option
                )
                return JsonResponse({
                    "id": detail.id,
                    "test_id": detail.test_id.id,
                    "user_id": detail.user_id.id,
                    "option_id": detail.option_id.id,
                    "message": "Дэлгэрэнгүй бичлэг амжилттай үүсгэгдлээ"
                }, status=201)
            else:
                return JsonResponse({"error": "Алдаатай JSON формат"}, status=400)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

@csrf_exempt
@jwt_required
def quiz_detail_detail(request, detail_id):
    try:
        detail = QuizDetail.objects.get(id=detail_id)
    except QuizDetail.DoesNotExist:
        return JsonResponse({"error": "Дэлгэрэнгүй бичлэг олдсонгүй"}, status=404)
    
    if request.method == "GET":
        return JsonResponse({
            "status": 200,
            "id": detail.id,
            "test_id": detail.test_id.id,
            "user_id": detail.user_id.id,
            "option_id": detail.option_id.id
        })
    elif request.method == "PUT":
        try:
            data = json.loads(request.body)
            if 'test_id' in data:
                detail.test_id = Quiz.objects.get(id=data['test_id'])
            if 'user_id' in data:
                detail.user_id = User.objects.get(id=data['user_id'])
            if 'option_id' in data:
                detail.option_id = Option.objects.get(id=data['option_id'])
            detail.save()
            return JsonResponse({"message": "Дэлгэрэнгүй бичлэг амжилттай шинэчлэгдлээ", "status": 200})
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)
    elif request.method == "DELETE":
        detail.delete()
        return JsonResponse({"message": "Дэлгэрэнгүй бичлэг амжилттай устгагдлаа", "status": 200})

# ==========================
# UserScore Views
# ==========================
@csrf_exempt
@jwt_required
def user_score_list(request):
    if request.method == "GET":
        scores = list(UserScore.objects.all().values())
        return JsonResponse({"status": 200, "data": scores})
    elif request.method == "POST":
        try:
            data = json.loads(request.body)
            if isinstance(data, list):
                objs = []
                for item in data:
                    user = User.objects.get(id=item['user_id'])
                    progress = QuizProgress.objects.get(id=item['quiz_progress_id'])
                    objs.append(UserScore(
                        user_id=user,
                        quiz_progress_id=progress,
                        total_score=item['total_score']
                    ))
                UserScore.objects.bulk_create(objs)
                return JsonResponse({"message": f"{len(objs)} онооны бичлэг амжилттай үүсгэгдлээ"}, status=201)
            elif isinstance(data, dict):
                user = User.objects.get(id=data['user_id'])
                progress = QuizProgress.objects.get(id=data['quiz_progress_id'])
                score = UserScore.objects.create(
                    user_id=user,
                    quiz_progress_id=progress,
                    total_score=data['total_score']
                )
                return JsonResponse({
                    "id": score.id,
                    "user_id": score.user_id.id,
                    "quiz_progress_id": score.quiz_progress_id.id,
                    "total_score": str(score.total_score),
                    "message": "Онооны бичлэг амжилттай үүсгэгдлээ"
                }, status=201)
            else:
                return JsonResponse({"error": "Алдаатай JSON формат"}, status=400)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

@csrf_exempt
@jwt_required
def user_score_detail(request, score_id):
    try:
        score = UserScore.objects.get(id=score_id)
    except UserScore.DoesNotExist:
        return JsonResponse({"error": "Онооны бичлэг олдсонгүй"}, status=404)
    
    if request.method == "GET":
        return JsonResponse({
            "status": 200,
            "id": score.id,
            "user_id": score.user_id.id,
            "quiz_progress_id": score.quiz_progress_id.id,
            "total_score": str(score.total_score)
        })
    elif request.method == "PUT":
        try:
            data = json.loads(request.body)
            if 'user_id' in data:
                score.user_id = User.objects.get(id=data['user_id'])
            if 'quiz_progress_id' in data:
                score.quiz_progress_id = QuizProgress.objects.get(id=data['quiz_progress_id'])
            if 'total_score' in data:
                score.total_score = data['total_score']
            score.save()
            return JsonResponse({"message": "Онооны бичлэг амжилттай шинэчлэгдлээ", "status": 200})
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)
    elif request.method == "DELETE":
        score.delete()
        return JsonResponse({"message": "Онооны бичлэг амжилттай устгагдлаа", "status": 200})
