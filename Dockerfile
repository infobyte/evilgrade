FROM perl:5.44-slim

# Install dependencies
RUN apt-get update && apt-get install -y \
    openssl \
    libssl-dev \
    libnet-ssleay-perl \
    libio-socket-ssl-perl \
    libdata-dump-perl \
    libterm-readline-gnu-perl \
    dnsmasq \
    curl \
    net-tools \
    iputils-ping \
    tcpdump \
    sudo \
    && rm -rf /var/lib/apt/lists/*

# Install additional Perl modules via CPAN
RUN perl -MCPAN -e 'CPAN::Shell->install("IO::Socket::SSL")' && \
    perl -MCPAN -e 'CPAN::Shell->install("Net::SSLeay")' && \
    perl -MCPAN -e 'CPAN::Shell->install("Data::Dump")'

# Create working directory
WORKDIR /evilgrade

# Copy evilgrade files
COPY . .

# Make scripts executable
RUN chmod +x evilgrade test_emudhra_authorized.sh setup_evilgrade.sh evilgrade.sh

# Create non-root user for testing
RUN useradd -m -s /bin/bash pentest && \
    usermod -aG sudo pentest && \
    echo "pentest ALL=(ALL) NOPASSWD:ALL" >> /etc/sudoers

# Set environment
ENV PERL5LIB=/evilgrade:/evilgrade/isrcore
ENV PATH=/evilgrade:$PATH

# Expose common ports
EXPOSE 80 443 8080 8443 53/udp

# Default command
CMD ["/bin/bash"]
