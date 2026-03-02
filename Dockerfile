FROM python:3.13-alpine AS builder

WORKDIR /app

COPY --from=ghcr.io/astral-sh/uv:latest /uv /bin/uv

COPY .python-version ./
COPY pyproject.toml ./
COPY uv.lock ./

RUN uv sync --no-dev --locked --no-editable

FROM python:3.13-alpine AS production

WORKDIR /app

COPY --from=builder --chown=root:root /app/.venv /app/.venv

COPY ./app /app/app

RUN chmod -R o=rx /app

RUN adduser -D -H worker
USER worker
EXPOSE 80

ENV PATH="/app/.venv/bin:$PATH"

CMD ["uvicorn", "app.main:app", "--port", "80", "--host", "0.0.0.0"]