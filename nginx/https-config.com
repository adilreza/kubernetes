server {
    server_name github.i;

    # Increase max request size if needed (Optional)
    client_max_body_size 100M;

    location / {
        allow 3.3.206.11; 
        allow 1.120.102.19;
        deny all;
        proxy_pass http://172.16.2.136:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;

        # Allow WebSocket connections (Optional)
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }

    # Handle errors (Optional)
    error_page 502 /502.html;
    location = /502.html {
        internal;
        root /usr/share/nginx/html;
    }

    listen 443 ssl; # managed by Certbot
    ssl_certificate /etc/letsencrypt/live/github.i/fullchain.pem; # managed by Certbot
    ssl_certificate_key /etc/letsencrypt/live/github.i/privkey.pem; # managed by Certbot
}

server {
    if ($host = github.i) {
        return 301 https://$host$request_uri;
    } # managed by Certbot

    listen 80;
    server_name github.i;
    return 404; # managed by Certbot
}
