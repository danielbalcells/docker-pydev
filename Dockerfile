FROM	python:2.7

# Add user daniel. Add to docker group, enable sudo permissions and create password
RUN \
	adduser --uid 1000 --disabled-password --gecos '' daniel && \
    	groupadd -g 999 docker && \
	usermod -a -G docker daniel && \
	usermod -a -G sudo daniel && \
	echo 'daniel:$1$jkbX2ik/$frBt1wS6fqLDQlwTSMapS1' | chpasswd -e
	

# Add system dependencies
ADD	apt-sys-dependencies.txt /tmp/apt-sys-dependencies.txt
RUN	apt-get update && apt-get install -y $(cat apt-sys-dependencies.txt)

# Add python dependencies
ADD	apt-py-dependencies.txt /tmp/apt-py-dependencies.txt
RUN 	apt-get update && apt-get install -y $(cat /tmp/apt-py-dependencies.txt)

RUN 	pip install --upgrade pip

ADD 	pip-dependencies.txt /tmp/pip-dependencies.txt
RUN 	pip install --upgrade -r /tmp/pip-dependencies.txt

# Clone Lasagne source tree
RUN	git clone https://github.com/Lasagne/Lasagne.git /home/daniel/lasagne

# Include bash configuration repo
ADD     bashrc /home/daniel/.bashrc

RUN	mkdir /home/daniel/.bash && \
	git clone https://github.com/danielbalcells/.bash.git \
		/home/daniel/.bash 

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

# Prepare volume for code
VOLUME	/home/daniel/code

# Add script to run stuff upon launching container
ADD	upon_start.sh /usr/local/bin/upon_start.sh
RUN	chmod +x /usr/local/bin/upon_start.sh

USER	daniel
WORKDIR	/home/daniel
CMD ["upon_start.sh"]
