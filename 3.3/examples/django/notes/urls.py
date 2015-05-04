from django.conf.urls import url

from . import views

urlpatterns = [
    # ex: /notes/
    url(r'^$', views.index, name='index'),
    # ex: /notes/create/25
    url(r'^create/(?P<how_many>\d+)$', views.create, name='create'),
]
