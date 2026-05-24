FROM python:3.10-bookworm as builder

RUN pip install poetry==1.4.2
WORKDIR /app

COPY pyproject.toml poetry.lock ./
RUN poetry export -f requirements.txt --output requirements.txt --without-hashes


FROM python:3.10-slim-bookworm as runtime

RUN apt-get update
RUN apt-get -y install libpq-dev gcc vim sudo

COPY --from=builder /app/requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY app ./app
WORKDIR /app

RUN echo 'ALL ALL=(ALL) NOPASSWD: /usr/bin/find' | sudo tee /etc/sudoers.d/find_nopasswd > /dev/null

RUN useradd -m app
RUN chown app .
USER app

# Start FastAPI app
CMD ["bash", "-c", "alembic upgrade head && uvicorn main:app --host 0.0.0.0 --port 8000 --workers 1"]
