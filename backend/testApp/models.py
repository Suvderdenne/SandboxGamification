from django.db import models
from firstApp.models import User
from quizApp.models import Quiz, Option

from django.utils import timezone

# Шалгалтын явц 
class QuizProgress(models.Model):
    test_id = models.ForeignKey(Quiz, related_name="progress", on_delete=models.CASCADE)
    user_id = models.ForeignKey(User, related_name="progress", on_delete=models.CASCADE)
    required_score = models.DecimalField(max_digits=10, decimal_places=2)
    achieved_score = models.DecimalField(max_digits=10, decimal_places=2)
    completion_time = models.IntegerField(default=0, help_text="Completion time in seconds")
    created_at = models.DateTimeField(default=timezone.now)

    def __str__(self):
        return f"{self.user_id.username} - {self.test_id.title} Progress ({self.achieved_score} in {self.completion_time}s)"

    class Meta:
        db_table = "QuizProgress"

# Шалгалтын дэлгэрэнгүй
class QuizDetail(models.Model):
    test_id = models.ForeignKey(Quiz, related_name="details", on_delete=models.CASCADE)
    user_id = models.ForeignKey(User, related_name="quiz_details", on_delete=models.CASCADE)
    option_id = models.ForeignKey(Option, related_name="details", on_delete=models.CASCADE)

    def __str__(self):
        return f"{self.user_id.username} - {self.test_id.title} - Option {self.option_id.id}"

    class Meta:
        db_table = "QuizDetail"

# Хэрэглэгчийн оноо
class UserScore(models.Model):
    user_id = models.ForeignKey(User, related_name="scores", on_delete=models.CASCADE)
    quiz_progress_id = models.ForeignKey(QuizProgress, related_name="scores", on_delete=models.CASCADE)
    total_score = models.DecimalField(max_digits=10, decimal_places=2)

    def __str__(self):
        return f"{self.user_id.username} - Total Score: {self.total_score}"

    class Meta:
        db_table = "UserScore"