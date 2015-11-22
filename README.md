# Prognition
[ ![Codeship Status for ISS-SOA/prognition](https://codeship.com/projects/3090fd20-7029-0133-38b1-4acedf45d268/status?branch=master)](https://codeship.com/projects/116454)

A web application to track and compare users' progress on Codecademy.com
- Useful for instructors to monitor student progress
- Useful for students to visualize their own progress

## Major Changes to UI:
- Mar 22, 2015: Made logo banner a responsive boostrap image
- Mar 17, 2015: Added first logo first site banner
- Feb 25, 2015: Added deadline date field to group check
- Feb 11, 2015: Added from/until date fields to cadets, description field to group check
- Feb 06, 2015: Upgraded look-and-feel using basic Twitter Bootstrap layout
- Jan 05, 2014: Added chart to cadet view

# Other Recent Changes:
- Nov ??, 2015: Added acceptance tests (Watir)
- Nov ??, 2015: Better checks for missing and invalid fields

Uses web service: http://cadetdynamo.herokuapp.com/api/v3/

## Testing

### Local Linux setup
For headless mode to work on Linux, install xvfb once:
```
apt-get install -y xvfb
```
(note that this is not needed on Codeship, which already has xvfb and Firefox installed)
(note that headless mode does not usually work on Mac OSX)

### Remote CI/CD Tests (CodeShip)
Test instructions:
```
bundle exec rackup &
bundle exec rake
```
