all: hello_you

install:
	apt-get -y install ghc; yum -y install ghc

s_hello:
	rm hello.hi hello.o hello 

hello_you: 
	ghc -o hello_you --make hello.hs

# scrub hello_you
s_hello_you:
	rm hello_you

# scrub everything
clean: s_hello_you s_hello
