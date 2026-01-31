#!/bin/bash

# 1. Ask for a commit message
echo "Enter commit message:"
read message

# 2. Add all changes
git add .

# 3. Commit with the provided message
git commit -m "$message"

# 4. Push to the main branch
git push origin main

echo "---------------------------------------"
echo "Done! Changes pushed to GitHub."