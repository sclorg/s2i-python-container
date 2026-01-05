FROM #IMAGE_NAME# # Replaced by sed in ct_test_app_dockerfile

# Add application sources with correct permissions for OpenShift
USER 0
ADD app-src .
RUN chown -R 1001:0 ./
USER 1001

# Install the dependencies
RUN pip install -U "pip>=19.3.1" && \
    pip install -r requirements.txt && \
    python manage.py collectstatic --noinput && \
    python manage.py migrate

# Run the application
CMD python manage.py runserver 0.0.0.0:8080
