export default {
    projectLink: 'https://github.com/reddavis/RedUx', // GitHub link in the navbar
    docsRepositoryBase: 'https://github.com/reddavis/RedUx', // base URL for the docs repository
    // titleSuffix: ' – RedUx',
    title: 'asd',
    nextLinks: true,
    prevLinks: true,
    search: true,
    customSearch: null, // customizable, you can use algolia for example
    darkMode: true,
    footer: true,
    footerText: `MIT ${new Date().getFullYear()} © Red Davis.`,
    footerEditLink: `Edit this page on GitHub`,
    logo: (
      <>
        {/* <svg>...</svg> */}
        <span><strong>RedUx</strong> - Simple State Management for Swift</span>
      </>
    ),
    head: (
      <>
        <title>RedUx - Simple State Management for Swift</title>
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <meta name="description" content="RedUx: Simple State Management for Swift" />
        <meta name="og:title" content="RedUx: Simple State Management for Swift" />
      </>
    ),
  }