interface Series {
  backgroundColor: string
  borderColor: string
}

interface Bands {
  warning: string
  caution: string
  notice: string
}

interface Colors {
  series: Series[]
  bands: Bands
}

const colors: Colors = {
  series: [
    {
      backgroundColor: '#e41a1c',
      borderColor: '#e41a1c'
    },
    {
      backgroundColor: '#377eb8',
      borderColor: '#377eb8'
    },
    {
      backgroundColor: '#4daf4a',
      borderColor: '#4daf4a'
    },
    {
      backgroundColor: '#984ea3',
      borderColor: '#984ea3'
    },
    {
      backgroundColor: '#ff7f00',
      borderColor: '#ff7f00'
    },
    {
      backgroundColor: '#ffff33',
      borderColor: '#ffff33'
    }
  ],
  bands: {
    warning: '#ffe8e8',
    caution: '#fffce8',
    notice: '#e8ffff'
  }
}

export default colors
