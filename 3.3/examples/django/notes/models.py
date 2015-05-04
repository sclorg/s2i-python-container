import random

from django.db import models

class Note(models.Model):
    text = models.CharField(max_length=100)
    created_at = models.DateTimeField(auto_now_add=True)
    updated_at = models.DateTimeField(auto_now=True)

    def __str__(self):
        return self.text

    @classmethod
    def create_random(cls, how_many=1):
        when = "yesterday today tomorrow".split()
        action = "go do eat play throw kick".split()
        what = "crazy ball cats bananas somewhere air".split()
        for x in range(how_many):
            cls.objects.create(text=" ".join(
                random.choice(t) for t in [when, action, what]
            ))
