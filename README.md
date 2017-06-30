# WannaBee

## For developers:

Before you start, create the database:

    sqlite3 empty.db < WannaBee/schema.sql

Then build the app.

## For users

### Setting up

Before starting it, go to the Settings app and add your username
and password. If you want, you can enable the "Download Images"
option so you have images next to your places, sets and items: It's
not enabled by default.

![Settings](https://raw.githubusercontent.com/MavEtJu/WannaBee/master/images/settings.png)

### First time run

When you run the first time, it will download all sets and contents.
This might take a while.

Also downloads the local places and your pouch.

### Next time run

Any next time it will download only the sets which were earlier
mentioned in the "Newer" section.

Also downloads the local places and your pouch.

### Tables

* Pull down to refresh.
* Swipe on items in sets to add them to your wishlist.
* Long tap to change the sorting mechanism.
* Images are downloaded on demand, so they will show up the next
  time the place / item / set is shown.

### Pouch

See the contents of your pouch. Swipe to remove an object from your wishlist.

![Pouch overview](https://raw.githubusercontent.com/MavEtJu/WannaBee/master/images/pouch-overview.png))

Long tap to change the sorting order.

![Pouch sorting](https://raw.githubusercontent.com/MavEtJu/WannaBee/master/images/pouch-sorting.png))

### Places

See the overview of the global places, the local places and the
out-of-reach places.

![Place overview](https://raw.githubusercontent.com/MavEtJu/WannaBee/master/images/places-overview.png))

![Place single](https://raw.githubusercontent.com/MavEtJu/WannaBee/master/images/places-single.png))

### Sets

See the overview of the sets.

![Sets overview](https://raw.githubusercontent.com/MavEtJu/WannaBee/master/images/sets-overview.png))

![Sets single](https://raw.githubusercontent.com/MavEtJu/WannaBee/master/images/sets-single.png))

### Newer

And now the interesting one:

* See the items in the places on your wishlist.
* See the items in the places which you don't have yet.
* See the items in the places which are newer than the ones in your set.
* See the items in your pouch which are newer than the ones in your set.

![Newer items](https://raw.githubusercontent.com/MavEtJu/WannaBee/master/images/newer.png))
