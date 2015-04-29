from django.http import HttpResponse

from .models import Note


def index(request):
    return HttpResponse("You have {} notes.".format(Note.objects.count()))

def create(request, how_many):
    Note.create_random(int(how_many))
    return HttpResponse("Created {} random notes.".format(how_many))
