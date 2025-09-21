# Stage 1: builder stage (build grpc + protobuf + redis)
FROM php:8.2 AS builder

# Install build dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    git \
    unzip \
    autoconf \
    automake \
    libtool \
    pkg-config \
    make \
    g++ \
    libssl-dev \
    libz-dev \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Set parallel build flags to utilize all cores, speed up make
ENV MAKEFLAGS="-j$(nproc)"

# Install PECL extensions in builder: grpc + protobuf + redis
RUN pecl install grpc-1.72.0 \
    && pecl install protobuf \
    && pecl install redis \
    && docker-php-ext-enable grpc protobuf redis

# Stage 2: final image
FROM php:8.2-apache

# Copy compiled .so and config files from builder
COPY --from=builder /usr/local/lib/php/extensions/no-debug-non-zts-*/grpc.so \
                     /usr/local/lib/php/extensions/no-debug-non-zts-*/grpc.so
COPY --from=builder /usr/local/lib/php/extensions/no-debug-non-zts-*/protobuf.so \
                     /usr/local/lib/php/extensions/no-debug-non-zts-*/protobuf.so
COPY --from=builder /usr/local/lib/php/extensions/no-debug-non-zts-*/redis.so \
                     /usr/local/lib/php/extensions/no-debug-non-zts-*/redis.so
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-grpc.ini \
                     /usr/local/etc/php/conf.d/docker-php-ext-grpc.ini
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-protobuf.ini \
                     /usr/local/etc/php/conf.d/docker-php-ext-protobuf.ini
COPY --from=builder /usr/local/etc/php/conf.d/docker-php-ext-redis.ini \
                     /usr/local/etc/php/conf.d/docker-php-ext-redis.ini

# Install soap in final image
RUN apt-get update && apt-get install -y --no-install-recommends \
    libxml2-dev \
    && docker-php-ext-install soap \
    && rm -rf /var/lib/apt/lists/*

# Copy your application code
COPY index.php /var/www/html/

