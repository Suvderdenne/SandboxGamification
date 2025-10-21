from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
import json

from .models import Topic, Quiz, Question, Option
from firstApp.decorators import jwt_required  

@csrf_exempt
@jwt_required
def topic_list(request):
    if request.method == "GET":
        topics = list(Topic.objects.all().values())
        return JsonResponse({"status": 200, "data": topics})

    elif request.method == "POST":
        try:
            data = json.loads(request.body)

            if isinstance(data, list):
                objs = [Topic(**item) for item in data]
                Topic.objects.bulk_create(objs)
                return JsonResponse({"message": f"{len(objs)} сэдэв амжилттай үүсгэлээ"}, status=201)
            elif isinstance(data, dict):
                topic = Topic.objects.create(**data)
                return JsonResponse({"id": topic.id, "title": topic.title, "message": "Сэдэв амжилттай нэмэгдлээ"}, status=201)
            else:
                return JsonResponse({"error": "JSON формат буруу байна"}, status=400)

        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)


@csrf_exempt
@jwt_required
def topic_detail(request, topic_id):
    try:
        topic = Topic.objects.get(id=topic_id)
    except Topic.DoesNotExist:
        return JsonResponse({"error": "Сэдэв олдсонгүй"}, status=404)

    if request.method == "GET":
        return JsonResponse({
            "status": 200,
            "id": topic.id,
            "title": topic.title,
            "description": topic.description,
            "order": topic.order
        })

    elif request.method == "PUT":
        try:
            data = json.loads(request.body)
            for key in ["title", "description", "order"]:
                if key in data:
                    setattr(topic, key, data[key])
            topic.save()
            return JsonResponse({"message": "Сэдэв амжилттай шинэчлэгдлээ", "status": 200})
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

    elif request.method == "DELETE":
        topic.delete()
        return JsonResponse({"message": "Сэдэв амжилттай устгагдлаа", "status": 200})


@csrf_exempt
@jwt_required
def quiz_list(request):
    if request.method == "GET":
        quizzes = list(Quiz.objects.all().values())
        return JsonResponse({"status": 200, "data": quizzes})

    elif request.method == "POST":
        try:
            data = json.loads(request.body)

            if isinstance(data, list):
                objs = [Quiz(**item) for item in data]
                Quiz.objects.bulk_create(objs)
                return JsonResponse({"message": f"{len(objs)} тест амжилттай үүсгэлээ"}, status=201)
            elif isinstance(data, dict):
                quiz = Quiz.objects.create(**data)
                return JsonResponse({"id": quiz.id, "title": quiz.title, "message": "Тест амжилттай нэмэгдлээ"}, status=201)
            else:
                return JsonResponse({"error": "JSON формат буруу байна"}, status=400)

        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)


@csrf_exempt
@jwt_required
def quiz_detail(request, quiz_id):
    try:
        quiz = Quiz.objects.get(id=quiz_id)
    except Quiz.DoesNotExist:
        return JsonResponse({"error": "Тест олдсонгүй"}, status=404)

    if request.method == "GET":
        return JsonResponse({
            "status": 200,
            "id": quiz.id,
            "title": quiz.title,
            "description": quiz.description,
            "topic_id": quiz.topic_id,
            "order": quiz.order
        })

    elif request.method == "PUT":
        try:
            data = json.loads(request.body)
            for key in ["title", "description", "topic_id", "order"]:
                if key in data:
                    setattr(quiz, key, data[key])
            quiz.save()
            return JsonResponse({"message": "Тест амжилттай шинэчлэгдлээ", "status": 200})
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

    elif request.method == "DELETE":
        quiz.delete()
        return JsonResponse({"message": "Тест амжилттай устгагдлаа", "status": 200})

@csrf_exempt
@jwt_required
def question_list(request):
    if request.method == "GET":
        questions = list(Question.objects.all().values())
        return JsonResponse({"status": 200, "data": questions})
    elif request.method == "POST":
        try:
            data = json.loads(request.body)
            question = Question.objects.create(**data)
            return JsonResponse({"id": question.id, "text": question.text, "message": "Асуулт амжилттай нэмэгдлээ"}, status=201)
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)


@csrf_exempt
@jwt_required
def question_detail(request, question_id):
    try:
        question = Question.objects.get(id=question_id)
    except Question.DoesNotExist:
        return JsonResponse({"error": "Асуулт олдсонгүй"}, status=404)

    if request.method == "GET":
        return JsonResponse({
            "status": 200,
            "id": question.id,
            "quiz_id": question.quiz_id,
            "text": question.text,
            "difficulty_level": question.difficulty_level,
            "order": question.order
        })

    elif request.method == "PUT":
        try:
            data = json.loads(request.body)
            for key in ["quiz_id", "text", "difficulty_level", "order"]:
                if key in data:
                    setattr(question, key, data[key])
            question.save()
            return JsonResponse({"message": "Асуулт амжилттай шинэчлэгдлээ", "status": 200})
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)

    elif request.method == "DELETE":
        question.delete()
        return JsonResponse({"message": "Асуулт амжилттай устгагдлаа", "status": 200})


@csrf_exempt
@jwt_required
def option_list(request):
    if request.method == "GET":
        options = list(Option.objects.all().values())
        return JsonResponse({"status": 200, "data": options})

    elif request.method == "POST":
        try:
            data = json.loads(request.body)
            if isinstance(data, list):
                objs = [Option(**item) for item in data]
                Option.objects.bulk_create(objs)
                created_options = [{"text": obj.text, "question_id": obj.question_id} for obj in objs]
                return JsonResponse({"message": f"{len(objs)} сонголт амжилттай үүсгэлээ", "options": created_options}, status=201)
            elif isinstance(data, dict):
                option = Option.objects.create(**data)
                return JsonResponse({"id": option.id, "text": option.text, "question_id": option.question_id, "message": "Сонголт амжилттай нэмэгдлээ"}, status=201)
            else:
                return JsonResponse({"error": "JSON формат буруу байна"}, status=400)

        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)


@csrf_exempt
@jwt_required
def option_detail(request, option_id):
    try:
        option = Option.objects.get(id=option_id)
    except Option.DoesNotExist:
        return JsonResponse({"error": "Сонголт олдсонгүй"}, status=404)

    if request.method == "GET":
        return JsonResponse({
            "status": 200,
            "id": option.id,
            "question_id": option.question_id,
            "text": option.text,
            "is_correct": option.is_correct
        })
    elif request.method == "PUT":
        try:
            data = json.loads(request.body)
            for key in ["question_id", "text", "is_correct"]:
                if key in data:
                    setattr(option, key, data[key])
            option.save()
            return JsonResponse({"message": "Сонголт амжилттай шинэчлэгдлээ", "status": 200})
        except Exception as e:
            return JsonResponse({"error": str(e)}, status=400)
    elif request.method == "DELETE":
        option.delete()
        return JsonResponse({"message": "Сонголт амжилттай устгагдлаа", "status": 200})
