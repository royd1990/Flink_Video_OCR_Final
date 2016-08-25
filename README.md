This program does video processing on flink with the help of openCV libraries and then does a character recongition on the processed video frames with the help of Tesseract libraries.
We use maven for dependency management. There is a pom.xml file which takes care of the all the required libraries. The experiment is run on the distributed system GRID5000.
There are some directories:
Resource: The resource folder contains some sample images used in the program for processing. Also there is the training set of tesseract which has the training data for the OCR. The video file is not present in the folder, as it occupies lot of space.
quickstart: This is the project directory. In the directory there is a target folder, where there is a jar file that runs on flink cluster. Everytime the code is changed do a "mvn clean package" to regenerate that jar file.
Scripts:Script for setting up cluster only in GRID5000.

Precautions to be taken for smooth execution:
1> Make sure the resource files are placed in correct path (according to the program). A change in program or in the location of file must be adjusted accordingly.
2> Keep a copy of training set of the Tesseract library in the sink folder.
3> Make sure all nodes are connected via passwordless ssh.

Current Issues: Performance is not impressive as there are some disk read and write. Also jpg can be changed to bmp to make the performance a bit better. The workaround would be to:
1> Hack the tesseract library so that it can read file im memory without going to disk.
2> Same for some openCV libraries.
3> Write own implementation of the libraries in native java.
4> Find some better libraries to do the job.
