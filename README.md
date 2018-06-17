## Ticket Viewer

##### Installation
Before installing the Ticket Viewer, please make sure that you have installed the following software:

1. Ruby. The viewer was written using Ruby 2.5.1 (might work with other versions). Please see [the link](https://www.ruby-lang.org/en/downloads/) for installation instructions. For Linux and OS X systems, please consider using [rbenv](https://github.com/rbenv/rbenv), [RVM](https://rvm.io/rvm/install), [chruby](https://github.com/postmodern/chruby) or another version management system.
2. Bundler. To install Bundler please run `gem install bundler`. You will need it to run `bundle install`. **Otherwise**, please install gems listed in the Gemfile manually with `gem install gem_name`. Replace `gem_name` with a gem name.
3. Git. Please see [the link](https://git-scm.com/downloads) for installation instructions. **Otherwise**, please [download](https://github.com/wyea/ticket-viewer/archive/master.zip) and unpack the repository manually.

NOTE: Technically, you don't need to install any gems to "run" the program. `dotenv` takes care of your environment variables, [that you can do yourself](https://wiki.archlinux.org/index.php/Environment_variables). `rspec` is only needed for testing the app. Having said that, running `bundle install` will definitelly make your life easier.

To install the viewer locally, please do the following:
```sh
git clone git@github.com:wyea/ticket-viewer.git
cd ticket-viewer
bundle install
```
Congratulations! The Ticket Viewer is installed and ready to use!

##### How to use it
Once you're in the `ticket-viewer` directory, simply run `ruby lib/ticket_viewer.rb`. To exit the program, please press Ctrl-D anytime.

###### Commands you can use:
1. `A`. See all tickets (or only first 25 if there are more than 25).
2. `T ###` (where ### is a ticket number. E.g. `T 53`). See a single ticket.
3. `N`. Next page, if there are more that 25 tickets in total.
4. `P`. Previous page, if there are more than 25 ticket in total.
5. `M`. Go back to the main menu.

##### Testing
To test the program, simply run `bundle exec rspec`.

##### Happy viewing!
