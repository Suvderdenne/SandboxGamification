from django.db import models

class Topic(models.Model):
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True, null=True)
    order = models.IntegerField(default=0)

    def __str__(self):
        return self.title
    
    class Meta:
        db_table = "Topic"
        ordering = ["order"]

class Quiz(models.Model):
    topic = models.ForeignKey(Topic, related_name="quizzes", on_delete=models.CASCADE)
    title = models.CharField(max_length=200)
    description = models.TextField(blank=True, null=True)
    order = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.title} ({self.topic.title})"
    
    class Meta:
        db_table = "Quiz"
        ordering = ["order"]

class Question(models.Model):
    quiz = models.ForeignKey(Quiz, related_name="questions", on_delete=models.CASCADE)
    text = models.CharField(max_length=500)
    difficulty_level = models.PositiveSmallIntegerField(
        default=50, 
        help_text="1-100: хэр хүнд шатлалтайг илэрхийлнэ"
    )
    order = models.IntegerField(default=0)

    def __str__(self):
        return f"{self.text} (Difficulty: {self.difficulty_level})"
    
    class Meta:
        db_table = "Question"

class Option(models.Model):
    question = models.ForeignKey(Question, related_name="options", on_delete=models.CASCADE)
    text = models.CharField(max_length=255)
    is_correct = models.BooleanField(default=False)

    def __str__(self):
        return f"{self.text}"
    
    class Meta:
        db_table = "Option"
