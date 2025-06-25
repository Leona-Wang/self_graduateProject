from django.shortcuts import render
from django.conf import settings
from django.http import JsonResponse
from django.views.decorators.csrf import csrf_exempt
from django.contrib.auth.models import User
import json

from rest_framework.views import APIView
from rest_framework.response import Response
from rest_framework import status
from rest_framework_simplejwt.tokens import RefreshToken

from google.auth.transport import requests as google_requests

from .Account import loginOrRegisterByGoogle


# Create your views here.
# views.py
@csrf_exempt
def testApi(request):
    if request.method == 'POST':
        data = json.loads(request.body)
        number = data.get('number', 0)
        result = number * 2
        return JsonResponse({'result': result})
    return JsonResponse({'error': 'Invalid request'}, status=400)


class LoginAndRegister(APIView):

    def post(self, request, *args, **kwargs):
        """根據有沒有 token 判斷是 google 註冊登入還是普通 email 註冊登入"""
        token = request.data.get('idToken')
        if token:
            result = loginOrRegisterByGoogle(token)
            return result
        else:
            return JsonResponse({'error': 'noToken'}, status=400)
        #return loginOrRegisterByEmail()
