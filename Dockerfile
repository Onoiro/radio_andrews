FROM python:3.12-slim

WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy dependency files
COPY pyproject.toml uv.lock ./

# Install dependencies
RUN uv sync --frozen --no-dev

# Copy source code
COPY src/ ./src/

# Add src to Python path
ENV PYTHONPATH=/app/src

# Create shared directory
RUN mkdir -p /app/data /shared

# Expose port
EXPOSE 5000

# Run with gunicorn
CMD ["uv", "run", "gunicorn", "--bind", "0.0.0.0:5000", "radio_andrews.app:create_app()"]
