import {RouteConfig} from 'vue-router'

import {
  AircraftIndex,
  AircraftNone,
  FlightsIndex,
  FlightsNone,
  FlightsShow,
  FlightsShared
} from 'views/index'

const routes: RouteConfig[] = [
  {path: '/', redirect: '/aircraft', name: 'root'},
  {
    path: '/aircraft', component: AircraftIndex, children: [
      {path: '', component: AircraftNone},
      {
        path: ':aircraftID',
        component: FlightsIndex,
        meta: {authenticated: true},
        children: [
          {
            path: '',
            component: FlightsNone,
            name: 'flights',
            meta: {authenticated: true}
          },
          {
            path: 'flights/:flightID',
            component: FlightsShow,
            name: 'flight',
            meta: {authenticated: true}
          }
        ]
      },
    ]
  },
  {path: '/flights/:shareToken', component: FlightsShared, name: 'shared_flight'}
]
export default routes
