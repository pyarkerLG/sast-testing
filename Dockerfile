FROM ruby:2.6.5

# Create a non-root user and group
RUN groupadd -r app && useradd -r -g app app

# Install system dependencies
RUN apt-get update -qq && apt-get install -y build-essential libpq-dev nodejs

# Create application directory and set ownership
RUN mkdir -p /myapp && chown -R app:app /myapp
WORKDIR /myapp

# Copy dependency files and install gems as root (needed for system gems)
ADD Gemfile /myapp/Gemfile
ADD Gemfile.lock /myapp/Gemfile.lock
RUN bundle install

# Copy application code and set ownership
ADD . /myapp
RUN chown -R app:app /myapp

# Switch to non-root user
USER app

# Expose the application port
EXPOSE 3000

# Set default command
CMD ["rails", "server", "-b", "0.0.0.0"]

