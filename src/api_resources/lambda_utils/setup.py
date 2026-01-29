from setuptools import setup, find_packages

setup(
    name='lambda_utils',
    version='0.0.1',
    packages=find_packages(
        exclude=['*_test.py'],  # empty by default
    )
)
