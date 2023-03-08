<script>
export default {
  props: ["title", "link", "rating", "ratings", "year", "image"]
}
</script>

<template>
  <h3>{{ title }}</h3>
  <img :src="image"/>
  <p>rated
    <b>{{ rating }}</b> by
    <b>{{ ratings }}</b> people (<b>{{ year }}</b>)
    <a :href="link">link</a>
  </p>
  <hr>
</template>
