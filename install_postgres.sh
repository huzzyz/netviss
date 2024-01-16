# Install virtualenv if not already installed
sudo apt-get install -y python3-venv

# Create a virtual environment in your project directory
python3 -m venv myenv

# Activate the virtual environment
source myenv/bin/activate

# Now install packages using pip
pip install bcrypt

# To deactivate the virtual environment when done
deactivate
