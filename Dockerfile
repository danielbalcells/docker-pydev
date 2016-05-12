FROM	python:2.7

# Add user daniel. Add to docker group, enable sudo permissions and
# create password
RUN \
	adduser --uid 1000 --disabled-password --gecos '' daniel && \
    	groupadd -g 999 docker && \
	usermod -a -G docker daniel && \
	usermod -a -G sudo daniel && \
	echo 'daniel:$1$jkbX2ik/$frBt1wS6fqLDQlwTSMapS1' | chpasswd -e


# Add system dependencies
ADD	apt-sys-dependencies.txt /tmp/apt-sys-dependencies.txt
RUN	apt-get update && apt-get install -y $(cat /tmp/apt-sys-dependencies.txt)

# Add python dependencies
ADD	apt-py-dependencies.txt /tmp/apt-py-dependencies.txt
RUN 	apt-get update && apt-get install -y $(cat /tmp/apt-py-dependencies.txt)

RUN 	pip install --upgrade pip

ADD 	pip-dependencies.txt /tmp/pip-dependencies.txt
RUN 	pip install --upgrade -r /tmp/pip-dependencies.txt

#	Python speech features library -install from source
RUN	git clone https://github.com/jameslyons/python_speech_features /home/daniel/python_speech_features && \
	cd /home/daniel/python_speech_features && \
	python setup.py install && \
	chown -R daniel:daniel /home/daniel/python_speech_features && \
	chmod -R 775 /home/daniel/python_speech_features

# Clone Lasagne source tree
RUN	git clone https://github.com/Lasagne/Lasagne.git /home/daniel/lasagne


# Enable CUDA support -taken from https://bitbucket.org/cseguramail/machinelearningdocker
#	Install dependencies
ADD     apt-cuda-dependencies.txt /tmp/apt-cuda-dependencies.txt
RUN     apt-get update && apt-get install -y $(cat /tmp/apt-cuda-dependencies.txt)
# 	Change to the /tmp directory
RUN 	cd /tmp && \
# 	Download run file
  	wget http://developer.download.nvidia.com/compute/cuda/7.5/Prod/local_installers/cuda_7.5.18_linux.run && \
# 	Make the run file executable and extract
  	chmod +x cuda_*_linux.run && ./cuda_*_linux.run -extract=`pwd` && \
# 	Install CUDA drivers (silent, no kernel)
  	./NVIDIA-Linux-x86_64-*.run -s --no-kernel-module && \
# 	Install toolkit (silent)  
  	./cuda-linux64-rel-*.run -noprompt && \
# 	Clean up
  	rm -rf *
# 	Add CUDA variables to path
ENV 	PATH=/usr/local/cuda/bin:$PATH \
 	LD_LIBRARY_PATH=/usr/local/cuda/lib64:$LD_LIBRARY_PATH  
#	Install cuDNN
# 	Install CUDA repo (needed for cuDNN)
ENV 	CUDA_REPO_PKG=cuda-repo-ubuntu1404_7.5-18_amd64.deb
RUN 	cd /tmp && \
	wget http://developer.download.nvidia.com/compute/cuda/repos/ubuntu1404/x86_64/$CUDA_REPO_PKG && \
	dpkg -i $CUDA_REPO_PKG && \
	rm $CUDA_REPO_PKG
# 	Install cuDNN v4
ENV 	ML_REPO_PKG=nvidia-machine-learning-repo_4.0-2_amd64.deb
RUN 	cd /tmp && \
	wget http://developer.download.nvidia.com/compute/machine-learning/repos/ubuntu1404/x86_64/$ML_REPO_PKG && \
	dpkg -i $ML_REPO_PKG && \
	apt-get update && apt-get install -y libcudnn4 libcudnn4-dev && \
	rm $ML_REPO_PKG
#	Install the same driver version as in baguette
RUN 	apt-get install -y libcuda1-352=352.93-0ubuntu1
#	Tell theano to use GPU
ADD	theanorc /home/daniel/.theanorc
RUN	chown daniel:daniel /home/daniel/.theanorc && \
	chmod -R 775 /home/daniel/.theanorc

# Include dotfiles configuration repo
RUN	mkdir /home/daniel/.dotfiles && \
	git clone https://github.com/danielbalcells/dotfiles.git \
		/home/daniel/.dotfiles && \
	/home/daniel/.dotfiles/configure.sh

# These sould be moved to the system dependencies and python dependencies
# sections above. I put them here for now to avoid rebuilding intermediate
# layers.

# Everything up-to-date for now...

# Add jupyter notebook server files
RUN	mkdir /home/daniel/.jupyter
RUN	jupyter-notebook --generate-config

#	Generate web certificates
RUN	openssl req -x509 -nodes -days 365 -newkey rsa:1024 \
	-keyout  /home/daniel/.jupyter/mykey.key \
	-out  /home/daniel/.jupyter/mycert.pem \
	-subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"

#	Alternatively, add them from external files
#ADD	mykey.key /home/daniel/.jupyter/mykey.key
#ADD	mycert.pem /home/daniel/.jupyter/mycert.pem

ADD	jupyter_notebook_config.py /home/daniel/.jupyter/jupyter_notebook_config.py
RUN	chown -R daniel:daniel /home/daniel/.jupyter && \
	chmod -R 775 /home/daniel/.jupyter
EXPOSE	8888

# Prepare volume for external code
VOLUME	/home/daniel/ext

# Add script to run stuff upon launching container
ADD	upon_start.sh /usr/local/bin/upon_start.sh
RUN	chmod +x /usr/local/bin/upon_start.sh

RUN	chown -R daniel:daniel /home/daniel

# TID user compatibility
RUN     adduser --uid 43005 --disabled-password --force-badname --gecos '' b.dbe && \
        groupadd -g 2520 speech && \
	usermod -a -G speech b.dbe && \
	usermod -a -G speech daniel
# Include bash configuration repo
ADD     bashrc /home/b.dbe/.bashrc
RUN     mkdir /home/b.dbe/dotfiles && \
        git clone https://github.com/danielbalcells/dotfiles.git \
                /home/b.dbe/.bash
# Prepare volume for code
VOLUME	/home/b.dbe/ext
# 	Add script to run stuff upon launching container
ADD	upon_start_tid.sh /usr/local/bin/upon_start_tid.sh
RUN	chmod +x /usr/local/bin/upon_start_tid.sh
# 	Add jupyter notebook server files
RUN	mkdir /home/b.dbe/.jupyter
#		Generate web certificates
RUN	openssl req -x509 -nodes -days 365 -newkey rsa:1024 \
	-keyout  /home/b.dbe/.jupyter/mykey.key \
	-out  /home/b.dbe/.jupyter/mycert.pem \
	-subj "/C=GB/ST=London/L=London/O=Global Security/OU=IT Department/CN=example.com"
ADD	jupyter_notebook_config_tid.py /home/b.dbe/.jupyter/jupyter_notebook_config.py
RUN	chown -R b.dbe:speech /home/b.dbe/ && \
	chmod -R 775 /home/b.dbe/


USER	daniel
WORKDIR	/home/daniel
CMD ["upon_start.sh"]
