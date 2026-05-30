FROM python:3.12-slim
 
RUN groupadd --gid 1001 appgroup \
    && useradd --uid 1001 --gid appgroup --no-create-home appuser \
    && mkdir -p /data && chown appuser:appgroup /data
 
WORKDIR /app
 
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
 
COPY --chown=appuser:appgroup . .
 
ENV PYTHONUNBUFFERED=1
 
USER appuser
 
EXPOSE 8000
 
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "2", "--threads", "4", "--timeout", "60", "app.main:app"]
 