FROM python:3.12-slim
LABEL maintainer="c.almeidarodrigo@gmail.com"

ENV PYTHONUNBUFFERED 1

RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libffi-dev \
    libssl-dev \
    curl \
    build-essential \
    && curl -sSL https://install.python-poetry.org | python3 - \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PATH="/root/.local/bin:$PATH"

WORKDIR /app

COPY ./pyproject.toml ./poetry.lock* /app/

RUN poetry config virtualenvs.create false \
    && poetry install --no-dev --no-interaction --no-ansi \
    && rm -rf /tmp/* \
    && adduser --disabled-password --no-create-home django-user

COPY ./app /app

EXPOSE 8000

USER django-user

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
