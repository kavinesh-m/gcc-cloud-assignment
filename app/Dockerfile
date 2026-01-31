# base image
FROM python:3.11-slim

# working directory
WORKDIR /app

# Copy requirements and install
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# port app runs on
EXPOSE 80

# run the app
CMD ["python", "app.py"]