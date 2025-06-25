from django.conf import settings
from django.http import JsonResponse
from django.contrib.auth.models import User

from rest_framework_simplejwt.tokens import RefreshToken

from google.auth.transport import requests as google_requests
from google.oauth2 import id_token


def loginOrRegisterByGoogle(token):
    """用 google oauth 判斷帳號可不可以使用"""
    try:
        idinfo = id_token.verify_oauth2_token(token, google_requests.Request(), settings.GOOGLE_CLIENT_ID)

        email = idinfo.get('email')
        name = idinfo.get('name')

        user, created = User.objects.get_or_create(email=email, defaults={'username': email, 'first_name': name})

        # 發 token 給前端（這裡用 simplejwt）
        refresh = RefreshToken.for_user(user)
        return JsonResponse({
            'access': str(refresh.access_token),
            'refresh': str(refresh),
            'user': {
                'username': user.username,
                'email': user.email,
            },
            'created': created
        },
                            status=200)

    except Exception as e:
        return JsonResponse({'error': str(e)}, status=400)
