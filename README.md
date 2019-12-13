# NeuroPAL-traces

This contains the scripts used to extract traces from GCaMP movies contained in [Yemeni et. al (2019)](https://www.biorxiv.org/content/10.1101/676312v1).

## Usage

Add information about where input data is located in `src/analyze.m`.

* `id_run`:
* `gcamp_run`: An `nd2` file that contains a 2D image timeseries of volumes obtained by sweeping through z.

The remainder of `analyze.m` has the workflow:

1. `preprocess_video.m`: The 2D timeseries will be converted to a 3D timeseries that is slightly filtered and compressed.
2. `get_ID_annotations.m`: Data from the ID run (including annotations of neurons) is ingested and matched to the first frame.
3. `get_traces.m`: Neurons are tracked throughout the time series, and calcium values are extracted.