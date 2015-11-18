# Prognition

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

Uses web service: http://cadetdynamo.herokuapp.com/api/v3/

## Testing

### Ubuntu setup
For headless mode to work, must first run:
```
apt-get install -y xvfb
```
(note that this is not needed on Codeship, which already has xvfb and Firefox installed)

### CI/CD Tests
Test instructions:
```
bundle exec rackup &
bundle exec rake
```
