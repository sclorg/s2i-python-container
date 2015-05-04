Django application example
==========================

This is a basic [Django](https://www.djangoproject.com/) project and some helper scripts to demonstrate how to deploy Python web applications with [OpenShift 3](http://www.openshift.org).

We will be using Django 1.8 and the [PostgreSQL](http://www.postgresql.org/) database.

OpenShift supports multiple build strategies. This example uses the Source-To-Image strategy, and the [Python 3.3 STI image](https://github.com/openshift/sti-python/tree/master/3.3) for producing application builds.

**WARNING**: this is a _proof of concept_ example and, therefore, the code available here is not meant to be used in production.


Application Build, Deploy, and Update Flow
------------------------------------------

Start by cloning this repository and changing your current directory appropriately:

```bash
git clone https://github.com/openshift/sti-python.git
cd sti-python/3.3/examples/django
```

Follow the instructions in https://github.com/openshift/origin/tree/master/examples/sample-app to build the `openshift` all-in-one binary and start your OpenShift 3 server and docker registry. You won't need to clone that repository, and you should use `sti-python/3.3/examples/django` as your working directory.

Before proceeding, make sure you have the OpenShift server running with a docker registry, a project and a user.


### Building your app ###

The file `application-template-stibuild.json` is a template describing the OpenShift entities that need to be created for this app.
You may want to inspect this file and tweak some configuration. Then, go on and create the entities:

```bash
osc process -f application-template-stibuild.json | osc create -f -
```

For more information about [templates](http://docs.openshift.org/latest/dev_guide/templates.html) and entities can be found in the [official documentation](http://docs.openshift.org/latest/welcome/index.html).

A build of your app should have been triggered automatically. Wait until the build completes with this command:

```bash
osc get builds --watch
```

The STI build process essentially copies your source files and install dependencies listed in `requirements.txt`, finally producing a new Docker image.


### Application deployment ###

An application deployment is triggered right after a build because of the ImageChange trigger.

Your database pod was deployed because of the ConfigChange trigger.

You should now the able to see your Django application running. To find out the IP and port of your service, run this:

```bash
osc describe service frontend
```


### One-off commands ###

The Django app requires the execution of some initial one-off commands in order to finish setting it up.

You can do that using the helper script `run-in-app-container.sh`.

```bash
./run-in-app-container.sh ./manage.py collectstatic
./run-in-app-container.sh kill -s SIGHUP 1          # restart gunicorn

./run-in-app-container.sh ./manage.py migrate
./run-in-app-container.sh ./manage.py createsuperuser
```


### Updates and redeploys ###

A build can be triggered automatically via a Github push hook, or manually with:

```bash
osc start-build django-demo-build
```


### Scaling ###

The `osc edit` command let's you change entities on-the-fly and have the new definitions reflected in your running cluster.

You can use that to change the number of replicas of your replication controller, the URL of the git repository of your application, etc.

```bash
# edit first frontend replication controller for immediate scaling;
osc edit rc $(osc get rc -l 'name=frontend-rc' -t '{{ with index}}{{ .metadata.name }}{{ end }}')

# or, alternatively, specify the replication controller name explicitly;
osc edit rc frontend-1

# you can also change the deployment config to affect future deploys
osc edit dc frontend
```

**Known limitation**: since we're collecting static files manually on a running container, after scaling up you application you'd need to repeat that step on each new instance in order to have static files served properly.


Cleaning up
-----------

You can use the `cleanup.sh` script to clean up your local environment after running this demo:

```bash
./cleanup.sh
```
