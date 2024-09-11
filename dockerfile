FROM python:3.12-slim
LABEL maintainer="c.almeidarodrigo@gmail.com"

ENV PYTHONUNBUFFERED 1

# Install system dependencies and Poetry
RUN apt-get update && apt-get install -y --no-install-recommends \
    gcc \
    libffi-dev \
    libssl-dev \
    curl \
    build-essential \
    && curl -sSL https://install.python-poetry.org | python3 - \
    && chmod +x /root/.local/bin/poetry \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Add Poetry to PATH
ENV PATH="/root/.local/bin:$PATH"

# Set working directory
WORKDIR /app

# Copy dependency files
COPY ./pyproject.toml ./poetry.lock* /app/

# Install dependencies using Poetry
RUN poetry config virtualenvs.create false \
    && poetry install --no-dev --no-interaction --no-ansi \
    && rm -rf /tmp/*

# Change ownership of app directory to django-user
RUN chown -R django-user /app

# Copy application code
COPY ./app /app

# Expose port 8000 for the Django development server
EXPOSE 8000

# Switch to the django-user for better security
USER django-user

# Run the Django development server using Poetry
CMD ["poetry", "run", "python", "manage.py", "runserver", "0.0.0.0:8000"]