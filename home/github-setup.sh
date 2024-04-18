#!/bin/bash

# Configurable variables
email="grantcuster@gmail.com"
ssh_key_path="$HOME/.ssh/github_rsa"

# Check if an SSH key already exists
if [ -f "$ssh_key_path" ]; then
	echo "SSH key already exists: $ssh_key_path"
else
	# Create a new SSH key
	echo "Creating a new SSH key for $email"
	ssh-keygen -t rsa -b 4096 -C "$email" -f "$ssh_key_path" -N ""

	# Start the ssh-agent in the background
	eval "$(ssh-agent -s)"
	ssh-add "$ssh_key_path"
fi

# Display the public SSH key
echo "Copy the following SSH key to GitHub:"
cat "${ssh_key_path}.pub"

# Optional: Configure SSH to always use this key for GitHub
echo "Host github.com
  IdentityFile $ssh_key_path" >>~/.ssh/config

echo "SSH key setup complete. Please add the public SSH key to your GitHub account. At https://github.com/settings/keys"
