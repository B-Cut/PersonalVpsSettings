# Based on https://gomakethings.com/automating-the-deployment-of-your-static-site-with-hugo-and-github/

from flask import Flask, request, Response
from datetime import datetime
import subprocess
import os
import sys
import hashlib
import hmac
import json

# Print messages to stderr
def err_print(*args, **kwargs) -> None:
    print(*args, file=sys.stderr, **kwargs)

# Append messages to a logfile
def log(content: str) -> None:
    with open("./deploy.log", "a") as logfile:
        logfile.write(datetime.today().strftime("%Y-%m-%d %H:%M:%S") + "> " + content)

app = Flask(__name__)

secret = os.environ['GH_DEPLOY_SECRET']

git_repo_dir = "~/hugo_dir"
public_dir = "/sites/protocoloipe.com/public"

# Check if environment variable and directory permissions are properly set
if secret is None:
    err_print("Could not retrieve deploy secret, aborting")
    exit(-1)

if not os.access(git_repo_dir, os.W_OK):
    err_print(f"Can't write to git repository directory \"{git_repo_dir}\", aborting")
    exit(-2)

if not os.access(public_dir, os.W_OK):
    err_print(f"Can't write to website public directory \"{public_dir}\", aborting")
    exit(-3)

@app.route('/', methods=['POST'])
def receiveHook():
    signature = request.headers['X-Hub-Signature-256']

    if signature is None:
        log("Error: HTTP header X-Hub-Signature-256 not present, deploy aborted")
        return Response("Operation Forbidden", 403)

    received_secret = signature.split('=')[1]
    hashed_secret = hashlib.sha256(bytes(secret, 'UTF-8')).digest()

    # Proper way to compare hashes
    if not hmac.compare_digest(received_secret, hashed_secret):
        log("Error: Received secret does not match")
        return Response("Operation Forbidden", 403)
    
    log("Received POST with correct secret, deploying...")

    data = json.loads(request['payload'])

    # Get commit messages for logging
    commits = [commit['message'] for commit in data['commits']]

    try:
        subprocess.run(["git", "fetch", "--all", "&&", "git", "reset", "--hard", "origin/main"], cwd=git_repo_dir)
        subprocess.run(["hugo", "build", "-c", git_repo_dir, "-d", public_dir])

        log("Deploy sucessfull. Commit Messages: " + ', '.join(commits))
    except Exception as e:
        log("Error: Deploy failed, message: " + e)
        return Response("Deploy failed", 500)

    return Response("Ok", 200)

if __name__ == '__main__':
    app.run(port= 3465) # Need to have a proper port defined for nginx redirection