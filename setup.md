# 0.0 Preface
These are instructions for installing & setting up everything for our ***app*** part of MLite (Rails, tailwind, postgresql). It was agreed we didn't need it for 
the machine learning libraries. As for other tools like AWS and Docker, no extra setup is needed really (except making an account, downloading the desktop app, etc.)

# 1.0 Installations
Note: read all the instructions and comments for all steps.

### 1.1 Install homebrew (package manager)
```
# to install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# open a new terminal, type to verify
brew
```

### 1.2 Install asdf (version manager)

```
brew install asdf

# put this in your bash file
export PATH="$HOME/.asdf/shims:$PATH"

# open a new terminal, type to verify
asdf
```

### 1.3 Install ruby (this will take like 5 min to execute)
```
asdf plugin add ruby
asdf install ruby 3.3.1
asdf global ruby 3.3.1

# open a new terminal, type to verify, should say something like 'ruby 3.3.1'
ruby -v
```

### 1.4 Install nodejs and yarn (needed for rails)
```
asdf plugin add nodejs
asdf install nodejs latest
asdf global nodejs latest

asdf plugin add yarn
asdf install nodejs yarn
asdf global nodejs yarn

# open a new terminal, type to verify
node -v
yarn -v
```

### 1.5 Install rails

```
# to install, might have to do 'sudo' if it throws an error
gem install rails

# open a new terminal, type to verify
rails -v
```

### 1.6 Install PostgreSQL (if you dont already have it)

```
brew install postgresql@14

# start postgres and check if its working
brew services start postgresql@14
brew services list
```

# 2.0 Setting up the App

## 2.1 Initialize a new Rails app

### 2.1.1 With PostgreSQL & Tailwind
Run this to initialize a boilerplate Rails app (if you encounter an error, refer to #2.1.2)
```
rails new my_app_1 --css tailwind --database=postgresql
```

### 2.1.2 (Optional) Without PostgreSQL
IMPORTANT: if at any time during initializing or later down the line you encounter a 'gem' issue with `pg` or a Postgres permission denied/connection error, you 
need to change how you set up Postgres and/or modify config files. So to makes things simpler for this tutorial, you can initialize with SQlite3 instead:

```
rails new my_app_1 --css tailwind
```

## 2.2 Start the app
- `cd` into the app directory `my_app_1/`
- run `rails db:create` to create the database (if you encounter an error here, refer to #2.1.2)
- run `rails server` to run the server
- go to `localhost:3000` in your browser, and there you go - you set up a Rails server

## 2.3 (Optional) Adding basic pages to the to check functionality
- run `rails generate scaffold Post title:string content:text`
  - this will create a `posts` table in your db with the fields `title` and `content`
- run `rails db:migrate` for changes to take affect
- run `rails server` to run the server
- go to `localhost:3000/posts` in your browser
- from here, you can see your posts in your db, add new posts, delete posts, edit posts (basically all CRUD operations)
  - FYI: default tailwind styles make everything look weird, but you can still click around the text like 'New post'
  - if youd prefer a basic look, recreate the app without the tailwind argument `--css tailwind`



