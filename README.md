# NeuroPAL-traces

This contains the scripts used to extract traces from GCaMP movies contained in the NeuroPAL publication, "NeuroPAL: A Multicolor Atlas for Whole-Brain Neuronal Identification in C. elegans". The publication is available here: https://www.cell.com/cell/fulltext/S0092-8674(20)31682-2

The NeuroPAL ID software, used in conjunction with these scripts, is available here: https://github.com/amin-nejat/CELL_ID

## Usage

Simply add information about where input data is located in `src/analyze.m`.

* `id_run`: the <experiment>_ID.mat file generated using the NeuroPAL ID software.
* `gcamp_run`: An `nd2` file that contains a 2D image time series of volumes obtained by sweeping through z.

The remainder of `analyze.m` has the workflow:

1. `preprocess_video.m`: The 2D time series will be converted to a 3D time series that is slightly filtered and compressed.
2. `get_ID_annotations.m`: Data from the ID run (including annotations of neurons) is ingested and matched to the first frame.
3. `get_traces.m`: Neurons are tracked throughout the time series, and calcium values are extracted.

The output of this script is an <experiment>traces.mat file containing the following:
input_neurons = the neurons ID'd in the <experiment>_ID.mat file, generated using the NeuroPAL ID software.
positions = an array of neuron positions (x,y,z), per video frame, corresponding to the input_neurons array.
trace_array = an array of GCaMP intensities, per video frame, corresponding to the input_neurons array.
times = the real time per video frame.

For further information please contact the corresponding authors.
