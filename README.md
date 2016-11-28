# docker-pydev
Docker image for deep learning with Python, Theano and Lasagne

## About
This Docker image is a self-contained environment for deep learning and machine learning using Python, Theano and Lasagne. It contains, among others, the following libraries:
-Vanilla Python 2.7
-Numpy/Scipy
-Pandas
-Matplotlib
-IPython and Jupyter notebook browser-based environment
-Theano
-TensorFlow
-SKLearn
-Python Speech Features

CUDA support is pre-installed, although you need to specify the specific driver version in the `Dockerfile` (see installation instructions below). Theano will use GPU unless instructed otherwise in `theanorc`.

Some other tools are installed in the basic Linux environment:
-Vim
-Git
-Sudo

## Setup
First of all, tweak the `Dockerfile` to your needs. Some things you might want to change:

-**Base Docker image**: I'm using `python:2.7` at the moment. Compatibility of the rest of the dependencies with Python 3 is not guaranteed.
-**Username and password**: You should specify the username and password for the in-container user. I've set it to `daniel`, with `uid=1000`, and added it to the `sudo` and `docker` groups. The password is piped to `chpasswd` in a hashed form. You can hash your password using `openssl passwd -1 -salt xyz yourpass`. If you change the username, make sure to find&replace daniel with your username in the Dockerfile (this should be parametrized but is not a priority ATM).
-**Dependencies**: Fill in `apt-py-dependencies`, `pip-dependencies`, and `sys-dependencies` with whatever you want to install from apt-get for python, from pip, and from apt-get for general system purposes respectively.
-**CUDA**: You might need to change the `libcuda` driver version specified in the `Dockerfile`. Theano GPU use is set in `theanorc`.
-**Jupyter notebook configuration**: The `Dockerfile` also loads `jupyter-notebook-configuration.py` to the image to get the desired Jupyter behavior. Edit this config file to disable the use of SSL certificates, enter a different hashed password, or change the default notebook directory, listening port, IP address...

Next, build the image:
`docker build -t pydev .`

At this point you might want to push it to a Docker registry:
`docker push username@domain.com:pydev`

To run the container, the easiest way is to use the included `launch.sh` scripts, depending on your OS. On Linux, for example:
`./linuxLaunch external_code_dir container_name`
This will create a container with the name `container_name`, mapping the directory `external_code_dir` from your host machine onto `/home/username/ext/`, and leaving it daemonized (in the background).

If you haven't specified otherwise, the Jupyter notebook server should be running on `localhost:8888`.

You can access the command line inside the container by typing:
`docker exec -it container_name bash`.

Happy dockerized coding!
