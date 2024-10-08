# MLite

## Description
MLite is a simplified machine learning platform designed to make building, training, and deploying models accessible for users without deep expertise in machine learning. Think of it as mini data scientist. Users can upload datasets and the app will give them analyses, they will receive automatic suggestions for the most suitable models, they can schedule training for these models with the option to deploy them for real-time predictions.

- Data Upload: Easily upload tabular datasets (e.g., CSV files) through the platform’s interface.
- Dataset Analysis: Analyze the dataset for features & meanginful datapoints/metrics.
- Model Suggestions: App suggests appropriate machine learning models such as linear regression, SVMs, decision trees or neural networks.
-	Model Training: Users can schedule model training jobs, which are run in the cloud to minimize local resource usage.
-	Model Deployment: Once training is complete, models can be deployed to a hosted environment for immediate use in future predictions.
- User-Friendly Interface: The platform offers an intuitive interface that guides users from data preparation to deployment, targeted for non-technical people.

## Team Members

### Mohammad Arjamand Ali (team leader)
Hi, I'm Mohammad. I'm a senior at EMU studying Computer Science & Mathematics. I'm currently working for [Truss](https://gettruss.io) as a Software Engineer and am working on a research project in NLP with transformers. My main areas of expertise are web dev with Ruby on Rails, machine learning, and AWS.

### Ali Almadhagi
My name is Ali Almadhagi and I am 22 years old, I work in the quality testing team at Volkswagen Group of America, I am graduating this semester, my major is Computer Science, I like to play and watch soccer and other sports.

### Brian Cong
Hello, Brian here 👋

I'm currently working at Liberty Robotics on fine tuning segmentation models; I'm also working on an AI detector algorithm in my spare time! I'm currently in the final year of my Bachelor's degree in computer science, and looking to begin my Master's degree once I finish!

### Nicholas Fiori
Hello. I'm Nicholas Fiori. I am a 22-year-old applied computer science major graduating this semester. I love just about anything related to automotive subjects, from racing to new advances to wrenching on a car.

### Ziad Sabri
I'm a computer science major graduation in the Winter 2025. I a currently work as an office manager at Eastern Michigan Housing and pursing a carrer in Data Enginering I like designing, constructing, maintaining and troubleshooting organization's data.

## Team Policy
- Absences (in meeting/classes) are good as long everyone is informed beforehand (unless emergencies), and work is done in a timely manner. 
- If there is clear intention for sabotage (like deleting), report to professor and fail them.
- For changing code someone else's code, its fine. Unless its a massive change, in which case letting the person know/keep them in the loop of the change.
- For scenarios where work is not done, we can distrubute work amongst others/include someone else as long as it is communicated beforehand. If its too complicated or too much of an overhead, it will be dealth with accourdingly by either pushing to next sprint or dropping it.
- Language of communication is English
- No issue with face mask. Can wear/not wear if you want.

## To Run
In order to run the docker image:
Install docker
```
git clone https://github.com/COSC481W-2024Fall/MLite.git
```
or use Github Desktop to clone the directory, then:
```
cd mlite
docker build -t mlite .
docker run -it -v ./src:/app/src mlite /bin/bash
```
## Setting up Ruby on Rails & postgres
```
# for homebrew, ignore if u already have it
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install postgresql@14
brew services start postgresql@14

brew install asdf
# add this to your .zshrc file
export PATH="$HOME/.asdf/shims:$PATH"

asdf plugin-add ruby
asdf plugin-add nodejs
asdf plugin-add yarn

asdf install ruby latest
asdf global ruby latest

asdf install nodejs latest
asdf global nodejs latest

asdf install yarn latest
asdf global yarn latest

# run these to make sure they are installed
ruby --version
node --version
yarn --version

gem install rails

rails -v

```
