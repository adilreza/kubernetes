server {
    listen 80;
    server_name github.i.s.com;

    location / {
        proxy_pass http://172.16.2.136:80;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
    }

    access_log /var/log/nginx/github_inb_access.log;
    error_log /var/log/nginx/github_inb_error.log;
}
