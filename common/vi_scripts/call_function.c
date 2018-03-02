#include "Python.h"
// gcc -g call_function.c -I/usr/include/python2.7 -L/usr/lib/python2.7/config-2.7 -lpython2.7
int call_pci_mem_write(const char *modname, const char *funcname,
                      unsigned long address, unsigned int size,
                      unsigned char *data_buf) {
  int i;
  int rtn_val;
  PyObject *mname = PyString_FromString(modname);
  PyObject *mod  = PyImport_Import(mname);
  PyObject *func = PyObject_GetAttrString(mod,funcname);
  PyObject *data_buf_list = PyList_New(size);
  for (i = 0; i <size; i++) {
     PyList_SET_ITEM(data_buf_list,i,PyInt_FromLong(data_buf[i]));
  }
  
  PyObject *args  = Py_BuildValue("kIO",address,size,data_buf_list);
  PyObject *kwargs= NULL;
  PyObject *result=PyObject_Call(func,args,kwargs);
  Py_DECREF(args);
  Py_XDECREF(kwargs);
  rtn_val=PyInt_AsLong(result);
  return rtn_val;
}
int call_pci_mem_read(const char *modname, const char *funcname,
                      unsigned long address, unsigned int size,
                      unsigned char *exp_buf, unsigned char *mask_buf) {
  int i;
  int rtn_val;
  PyObject *mname = PyString_FromString(modname);
  PyObject *mod  = PyImport_Import(mname);
  PyObject *func = PyObject_GetAttrString(mod,funcname);
  PyObject *exp_buf_list = PyList_New(size);
  PyObject *mask_buf_list = PyList_New(size);
  for (i = 0; i <size; i++) {
     PyList_SET_ITEM(exp_buf_list,i,PyInt_FromLong(exp_buf[i]));
     PyList_SET_ITEM(mask_buf_list,i,PyInt_FromLong(mask_buf[i]));
  }
  
  PyObject *args  = Py_BuildValue("kIOO",address,size,exp_buf_list,mask_buf_list);
  PyObject *kwargs= NULL;
  PyObject *result=PyObject_Call(func,args,kwargs);
  Py_DECREF(args);
  Py_XDECREF(kwargs);
  rtn_val=PyInt_AsLong(result);
  return rtn_val;
}
int main() {
  int rtn_val;
  int i;
  unsigned long address;
  unsigned int size;
  Py_Initialize();
  PyRun_SimpleString("import sys");
  PyRun_SimpleString("sys.path.append('.')");
  PyRun_SimpleString("import pci");
  

  
  address = 0x6666666666666660;
  size=16;
  unsigned char exp_buf[]={65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80,0};
  unsigned char mask_buf[]={0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f, 0x0f,0};
  rtn_val=call_pci_mem_read("pci", "mem_read",
                            address, size,
                            exp_buf, mask_buf);
  if (rtn_val==0)
    printf("pci mem write succeeded\n");
  else
    printf("pci mem write failed\n");

  address = 0x7777777777777770;
  size=16;
  unsigned char data_buf[]={0x65,0x66,0x67,0x68,0x69,0x70,0x71,0x72,0x73,0x74,0x75,0x76,0x77,0x78,0x79,0x80,0};
  rtn_val=call_pci_mem_write("pci", "mem_write",
                            address, size,
                            data_buf);
  if (rtn_val==0)
    printf("pci mem write succeeded\n");
  else
    printf("pci mem write failed\n");
  Py_Finalize();
  return 0;
}
