<script>
import init from "./assets/init.txt?raw"
import * as cheerio from "cheerio"
import axios from "axios"
import Movie from "./components/Movie.vue"

export default {
  data() {
    return {
      stop_button_enabled: false,
      go_button_enabled: true,
      initial_justwatch_input: init,
      justwatch_input: "",
      min_ratings: 10000,
      movies: []
    }
  },
  components: {
    Movie
  },
  methods: {
    scrape() {
      this.stop_button_enabled = true
      this.go_button_enabled = false
      let $ = cheerio.load(this.justwatch_input || this.initial_justwatch_input, null, false)
      const data = this
      $("a.title-list-grid__item--link").each(function(i) {
        setTimeout(() => {
          if(!data.stop_button_enabled) {
            return false
          }

          // console.log("https://justwatch.com" + $(this).attr("href"))
          axios.get("https://justwatch.com" + $(this).attr("href"))
          .then(res => {
            $ = cheerio.load(res.data)
            const image = $("img[src*=images]").attr("src")
            // console.log(image)

            // console.log($("a[href*=imdb.com]").attr("href"))
            axios.get($("a[href*=imdb.com]").attr("href"))
            .then(res => {
              $ = cheerio.load(res.data)
              const ratings_txt = $("div.sc-e457ee34-3").first().text()
              // console.log(ratings_txt)
              let ratings
              if(ratings_txt.includes("M")) {
                ratings = parseFloat(ratings_txt.replace("M","")) * 1000000
              } else if(ratings_txt.includes("K")) {
                ratings = parseFloat(ratings_txt.replace("K","")) * 1000
              } else {
                ratings = parseInt(ratings_txt)
              }
              // console.log(ratings)
              if(ratings >= data.min_ratings) {
                const title = $("h1").first().text()
                // console.log(title)
                const link = res.config.url
                // console.log(link)
                const rating = $("span.sc-e457ee34-1").first().text()
                // console.log(rating)
                const year = $("a[href*=releaseinfo]").first().text()
                // console.log(year)
                data.movies.push({
                  title: title,
                  link: link,
                  rating: rating,
                  ratings: ratings,
                  year: year,
                  image: image
                })
              }
            })
            .catch(e => {
              console.log(e)
            })

          })
          .catch(e => {
            console.log(e)
          })

        }, 421 * i++ + Math.floor(i / 100) * 121000) // try and error
      })
    },
    stop() {
      this.stop_button_enabled = false
      setTimeout(() => {
        this.go_button_enabled = true
      }, 4000)
    }
  }
}
</script>

<template>
  <h1>Settings</h1>
  <p>chromium --disable-web-security --user-data-dir="[some directory here]"</p>
  <div>Minimum number of ratings:
    <input v-model.number="min_ratings"/>
  </div>
  <div>Paste div.title-list-grid here:
    <input v-model="justwatch_input" placeholder="optional"/>
  </div>
  <div>
    <button v-if="stop_button_enabled" @click="stop">Stop</button>
    <button v-else-if="go_button_enabled" @click="scrape">Go</button>
    <span v-else>stopping...</span>
  </div>
  <h1>Movies</h1>
  <hr/>
  <Movie
    v-for="movie in movies"
    :title="movie.title"
    :link="movie.link"
    :rating="movie.rating"
    :ratings="movie.ratings"
    :year="movie.year"
    :image="movie.image"
  />
</template>
