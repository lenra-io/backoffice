<div id="top"></div>
<!--
*** This README was created with https://github.com/othneildrew/Best-README-Template
-->



<!-- PROJECT SHIELDS -->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![GPL License][license-shield]][license-url]



<!-- PROJECT LOGO -->
<br />
<div align="center">

<h3 align="center">Lenra Client Backoffice</h3>

  <p align="center">
    The Lenra Client Backoffice in Flutter.
    <br />
    <br />
    <a href="https://github.com/lenra-io/backoffice/issues">Report Bug</a>
    ·
    <a href="https://github.com/lenra-io/backoffice/issues">Request Feature</a>
  </p>
</div>

This repository gives you the possibility to create, manage and deploy your applications on Lenra.

<!-- GETTING STARTED -->

## Prerequisites

- [flutter](https://flutter.dev/docs/get-started/install) + [web setup](https://flutter.dev/docs/get-started/web)

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- USAGE EXAMPLES -->
## Usage

On the server project, you need to have a running instance of the [Lenra Server](https://github.com/lenra-io/server) and have created an OAuth client for the backoffice with the next command:
```sh
mix create_oauth2_client backoffice
```

Run flutter app with chrome
```sh
flutter run -d chrome --web-port 10000 --dart-define=LENRA_SERVER_URL=http://localhost:4000 --dart-define=OAUTH_CLIENT_ID=<client_id_from_the_previous_cmd>
```

Run flutter test
```sh
flutter test
```

Run flutter test with coverage report (need to install lcov)
```sh
flutter test --coverage && lcov --list coverage/lcov.info
```

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTRIBUTING -->
## Contributing

Contributions are what make the open source community such an amazing place to learn, inspire, and create. Any contributions you make are **greatly appreciated**.

If you have a suggestion that would make this better, please open an issue with the tag "enhancement".
Don't forget to give the project a star if you liked it! Thanks again!

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- LICENSE -->
## License

Distributed under the **GPL** License. See [LICENSE](./LICENSE) for more information.

<p align="right">(<a href="#top">back to top</a>)</p>



<!-- CONTACT -->
## Contact

Lenra - [@lenra_dev](https://twitter.com/lenra_dev) - contact@lenra.io

Project Link: [https://github.com/lenra-io/backoffice](https://github.com/lenra-io/backoffice)

<p align="right">(<a href="#top">back to top</a>)</p>


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/lenra-io/backoffice.svg?style=for-the-badge
[contributors-url]: https://github.com/lenra-io/backoffice/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/lenra-io/backoffice.svg?style=for-the-badge
[forks-url]: https://github.com/lenra-io/backoffice/network/members
[stars-shield]: https://img.shields.io/github/stars/lenra-io/backoffice.svg?style=for-the-badge
[stars-url]: https://github.com/lenra-io/backoffice/stargazers
[issues-shield]: https://img.shields.io/github/issues/lenra-io/backoffice.svg?style=for-the-badge
[issues-url]: https://github.com/lenra-io/backoffice/issues
[license-shield]: https://img.shields.io/github/license/lenra-io/backoffice.svg?style=for-the-badge
[license-url]: https://github.com/lenra-io/backoffice/blob/master/LICENSE

