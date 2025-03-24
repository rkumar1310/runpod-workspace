# Base image
FROM nvidia/cuda:12.2.0-runtime-ubuntu22.04

# Install basic stuff including OpenSSH
RUN apt-get update && apt-get install -y \
    openssh-server \
    git \
    curl \
    nano \
    && mkdir /var/run/sshd

# Set root password (or better: use keys)
RUN echo 'root:runpod' | chpasswd

# SSH keep-alive settings (optional but recommended)
RUN echo "PermitRootLogin yes" >> /etc/ssh/sshd_config && \
    echo "PasswordAuthentication yes" >> /etc/ssh/sshd_config && \
    echo "ClientAliveInterval 60" >> /etc/ssh/sshd_config && \
    echo "ClientAliveCountMax 1000" >> /etc/ssh/sshd_config


# Create SSH directory and placeholder file for RunPod to inject its key
RUN mkdir -p /root/.ssh && \
    touch /root/.ssh/authorized_keys && \
    chmod 700 /root/.ssh && \
    chmod 600 /root/.ssh/authorized_keys

# Expose SSH port
EXPOSE 22

# Copy startup script
COPY startup.sh /opt/startup.sh
RUN chmod +x /opt/startup.sh

# Start SSH and your setup script
CMD /opt/startup.sh