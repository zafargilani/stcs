from setuptools import setup

setup(name='debot',
      version='0.1',
      description='Find bot accounts in Twitter',
      url='https://github.com/nchavoshi/debot_api',
      author='Nikan Chavoshi',
      author_email='chavoshi@unm.edu',
      license='MIT',
      packages=['debot'],
      install_requires=[
          'requests',
          ],
      )
