FROM python:3.10-slim-buster

WORKDIR /cownter

# Install os dependences
RUN apt-get update && \
    apt-get install -y ffmpeg libsm6 libxext6

# Copy the requirements.txt file
COPY requirements.txt .

# Activate dependencies in the virtual environment
# Install dependencies in the virtual environment
RUN pip install --no-cache-dir -r requirements.txt

# Copy the function app
COPY . /cownter

# Set the listening port
EXPOSE 80

# Run api
CMD ["uvicorn", "web:app", "--host", "0.0.0.0", "--port", "80"]