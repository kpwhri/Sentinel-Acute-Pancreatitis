<!-- PROJECT SHIELDS -->
<!--
*** I'm using markdown "reference style" links for readability.
*** Reference links are enclosed in brackets [ ] instead of parentheses ( ).
*** See the bottom of this document for the declaration of the reference variables
*** for contributors-url, forks-url, etc. This is an optional, concise syntax you may use.
*** https://www.markdownguide.org/basic-syntax/#reference-style-links
-->
[![Contributors][contributors-shield]][contributors-url]
[![Forks][forks-shield]][forks-url]
[![Stargazers][stars-shield]][stars-url]
[![Issues][issues-shield]][issues-url]
[![MIT License][license-shield]][license-url]
[![LinkedIn][linkedin-shield]][linkedin-url]



<!-- PROJECT LOGO -->
<br />
<div>
  <p>
    <!--a href="https://github.com/kpwhri/sentinel_ap">
      <img src="images/logo.png" alt="Logo">
    </a-->
  </p>

  <h2 align="center">Detection of Acute Pancreatitis (Project of Sentinel Initiative)</h2>

  <p>
    Sentinel Initiative Project for Detection of Acute Pancreatitis
  </p>
</div>


<!-- TABLE OF CONTENTS -->
## Table of Contents

* [About the Project](#about-the-project)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Usage](#usage)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [License](#license)
* [Contact](#contact)
* [Acknowledgements](#acknowledgements)



<!-- ABOUT THE PROJECT -->
## About The Project

Sentinel Initiative Project for Detection of Acute Pancreatitis.


<!-- GETTING STARTED -->
## Getting Started

The pipeline for developing a model to determine Acute Pancreatitis will involve several steps:
1. Extraction of variables from NLP
   * implemented in Python
   * [Acute Pancreatitis Runrex](https://github.com/kpwhri/apanc-runrex) for implementation details
2. Extraction of variables from structured data 
   * Code provided in SAS (requires version 9.4+)
   * assumes implementation of [Sentinel Common Data Model](https://www.sentinelinitiative.org/methods-data-tools) and [HCSRN VDW](https://www.hcsrn.org/en/Resources/VDW/)


### Prerequisites

* Clinical Text (for NLP component)
* Data Warehouse with HCSRN VDW and Sentinel Data Model components

### Installation
 


<!-- USAGE EXAMPLES -->
## Usage

### 1. Run NLP on Clinical Text

1. `TODO: How was corpus selected?`
2. Run [`apanc-runrex`](https://github.com/kpwhri/apanc-runrex/) application on assembled notes.

### 2. Create Lab covariate data

1.  `TODO: Intro to lab data covariates package`
2. Download and run SAS program package abc

### 3. Extracting Structured Data

1. `TODO: Intro to extraction`
2. Download and run SAS program package xyz

### 3. Merge Datasets

`TODO: How was this done?`


### 4. Running Model

`TODO:`

## Versions

<!-- Uses [SEMVER](https://semver.org/). -->

Updates/changes are not expected, please use most recent version, or find commit closer to the desired time period. See https://github.com/kpwhri/sentinel_ap/releases.

<!-- ROADMAP -->
## Roadmap

See the [open issues](https://github.com/kpwhri/sentinel_ap/issues) for a list of proposed features (and known issues).



<!-- CONTRIBUTING -->
## Contributing

Any contributions you make are **greatly appreciated**.

1. Fork the Project
2. Create your Feature Branch (`git checkout -b feature/AmazingFeature`)
3. Commit your Changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the Branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request


<!-- LICENSE -->
## License

Distributed under the MIT License. See `LICENSE` or https://kpwhri.mit-license.org for more information.



<!-- CONTACT -->
## Contact

Please use the [issue tracker](https://github.com/kpwhri/sentinel_ap/issues). 


## Disclaimer

* This is not a Sentinel Initiative-supported project.

<!-- ACKNOWLEDGEMENTS -->
## Acknowledgements

* This work was funded as part of the [Sentinel Initiative](https://www.fda.gov/safety/fdas-sentinel-initiative).
  * However, this is not a Sentinel Initiative-supported project.


<!-- MARKDOWN LINKS & IMAGES -->
<!-- https://www.markdownguide.org/basic-syntax/#reference-style-links -->
[contributors-shield]: https://img.shields.io/github/contributors/kpwhri/sentinel_ap.svg?style=flat-square
[contributors-url]: https://github.com/kpwhri/sentinel_ap/graphs/contributors
[forks-shield]: https://img.shields.io/github/forks/kpwhri/sentinel_ap.svg?style=flat-square
[forks-url]: https://github.com/kpwhri/sentinel_ap/network/members
[stars-shield]: https://img.shields.io/github/stars/kpwhri/sentinel_ap.svg?style=flat-square
[stars-url]: https://github.com/kpwhri/sentinel_ap/stargazers
[issues-shield]: https://img.shields.io/github/issues/kpwhri/sentinel_ap.svg?style=flat-square
[issues-url]: https://github.com/kpwhri/sentinel_ap/issues
[license-shield]: https://img.shields.io/github/license/kpwhri/sentinel_ap.svg?style=flat-square
[license-url]: https://kpwhri.mit-license.org/
[linkedin-shield]: https://img.shields.io/badge/-LinkedIn-black.svg?style=flat-square&logo=linkedin&colorB=555
[linkedin-url]: https://www.linkedin.com/company/kaiserpermanentewashingtonresearch
<!-- [product-screenshot]: images/screenshot.png -->
